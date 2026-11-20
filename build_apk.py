import os
import sys
import subprocess
import shutil
import zipfile

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.join(BASE_DIR, "android_build")
SRC_DIR = os.path.join(PROJECT_DIR, "src")
RES_DIR = os.path.join(PROJECT_DIR, "res")
ASSETS_DIR = os.path.join(PROJECT_DIR, "assets")
MANIFEST = os.path.join(PROJECT_DIR, "AndroidManifest.xml")
BUILD_DIR = os.path.join(PROJECT_DIR, "build")
GEN_DIR = os.path.join(BUILD_DIR, "gen")
OBJ_DIR = os.path.join(BUILD_DIR, "obj")
DEX_DIR = os.path.join(BUILD_DIR, "dex")
BIN_DIR = os.path.join(BUILD_DIR, "bin")

JDK_DIR = os.path.join(BASE_DIR, "jdk-17", "jdk-17.0.12+7")
JDK_BIN = os.path.join(JDK_DIR, "bin")
SDK_DIR = r"C:\Users\lungh\AppData\Local\Android\Sdk"
BUILD_TOOLS = os.path.join(SDK_DIR, "build-tools", "35.0.1")
ANDROID_JAR = os.path.join(SDK_DIR, "platforms", "android-35", "android.jar")

JAVAC = os.path.join(JDK_BIN, "javac.exe")
KEYTOOL = os.path.join(JDK_BIN, "keytool.exe")
JAR = os.path.join(JDK_BIN, "jar.exe")
AAPT2 = os.path.join(BUILD_TOOLS, "aapt2.exe")
D8 = os.path.join(BUILD_TOOLS, "d8.bat")
ZIPALIGN = os.path.join(BUILD_TOOLS, "zipalign.exe")
APKSIGNER = os.path.join(BUILD_TOOLS, "apksigner.bat")

KEYSTORE_PATH = os.path.join(PROJECT_DIR, "debug.keystore")
FINAL_APK = os.path.join(BASE_DIR, "MaxMinDesign.apk")

def run(cmd, desc, env=None):
    print(f"\n---> {desc} ...")
    res = subprocess.run(cmd, shell=isinstance(cmd, str), capture_output=True, text=True, env=env)
    if res.stdout:
        print(f"[STDOUT]: {res.stdout.strip()}")
    if res.stderr:
        print(f"[STDERR]: {res.stderr.strip()}")
    if res.returncode != 0:
        raise RuntimeError(f"Step '{desc}' failed with exit code {res.returncode}")
    print(f"SUCCESS: {desc}")

def main():
    for d in [GEN_DIR, OBJ_DIR, DEX_DIR, BIN_DIR]:
        os.makedirs(d, exist_ok=True)
    
    # 1. Compile Resources with AAPT2
    compiled_res = os.path.join(BUILD_DIR, "compiled_res.zip")
    run([AAPT2, "compile", "--dir", RES_DIR, "-o", compiled_res], "Compile Resources with AAPT2")

    # 2. Link Resources and Manifest with AAPT2
    base_apk = os.path.join(BUILD_DIR, "base.apk")
    run([
        AAPT2, "link",
        "-I", ANDROID_JAR,
        "--manifest", MANIFEST,
        "-o", base_apk,
        "--java", GEN_DIR,
        compiled_res,
        "-A", ASSETS_DIR,
        "--auto-add-overlay"
    ], "Link Resources and generate R.java with AAPT2")

    # Find all java files
    java_files = []
    for root, dirs, files in os.walk(SRC_DIR):
        for f in files:
            if f.endswith(".java"):
                java_files.append(os.path.join(root, f))
    for root, dirs, files in os.walk(GEN_DIR):
        for f in files:
            if f.endswith(".java"):
                java_files.append(os.path.join(root, f))

    # 3. Compile Java with javac
    run([JAVAC, "-cp", ANDROID_JAR, "-d", OBJ_DIR] + java_files, "Compile Java sources with javac")

    # 4. Dex with D8 with --lib ANDROID_JAR
    class_files = []
    for root, dirs, files in os.walk(OBJ_DIR):
        for f in files:
            if f.endswith(".class"):
                class_files.append(os.path.join(root, f))

    custom_env = os.environ.copy()
    custom_env["JAVA_HOME"] = JDK_DIR
    custom_env["PATH"] = JDK_BIN + ";" + custom_env.get("PATH", "")
    
    run([D8, "--lib", ANDROID_JAR, "--output", DEX_DIR] + class_files, "DEX bytecode with D8", env=custom_env)

    # 5. Insert classes.dex into base.apk
    dex_file = os.path.join(DEX_DIR, "classes.dex")
    with zipfile.ZipFile(base_apk, 'a') as apk_zip:
        apk_zip.write(dex_file, "classes.dex")

    # 6. Align APK with zipalign
    aligned_apk = os.path.join(BUILD_DIR, "aligned.apk")
    if os.path.exists(aligned_apk):
        os.remove(aligned_apk)
    run([ZIPALIGN, "-v", "-p", "4", base_apk, aligned_apk], "Align APK with zipalign")

    # 7. Create Keystore if needed
    if not os.path.exists(KEYSTORE_PATH):
        run([
            KEYTOOL, "-genkeypair", "-v",
            "-keystore", KEYSTORE_PATH,
            "-storepass", "android",
            "-alias", "androiddebugkey",
            "-keypass", "android",
            "-keyalg", "RSA",
            "-keysize", "2048",
            "-validity", "10000",
            "-dname", "CN=Android Debug,O=Android,C=US"
        ], "Generate Debug Keystore with keytool")

    # 8. Sign APK with apksigner
    if os.path.exists(FINAL_APK):
        os.remove(FINAL_APK)
    run([
        APKSIGNER, "sign",
        "--ks", KEYSTORE_PATH,
        "--ks-pass", "pass:android",
        "--ks-key-alias", "androiddebugkey",
        "--key-pass", "pass:android",
        "--out", FINAL_APK,
        aligned_apk
    ], "Sign APK with apksigner", env=custom_env)

    # 9. Verify APK
    run([APKSIGNER, "verify", "--verbose", FINAL_APK], "Verify signed APK", env=custom_env)

    print("\n" + "="*60)
    print("🎉 BUILD SUCCESSFUL! 🎉")
    print(f"Output APK: {FINAL_APK}")
    print(f"Size: {os.path.getsize(FINAL_APK) / 1024 / 1024:.2f} MB ({os.path.getsize(FINAL_APK):,} bytes)")
    print("="*60)

if __name__ == "__main__":
    main()
