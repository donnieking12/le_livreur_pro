# Visual Studio Installation Guide for Le Livreur Pro

## Prerequisites
- Windows 10/11 (64-bit)
- At least 8GB RAM
- At least 20GB free disk space

## Installation Steps

### Step 1: Download Visual Studio Community
1. Go to https://visualstudio.microsoft.com/downloads/
2. Download "Visual Studio Community" (free for individual developers)
3. Run the downloaded installer

### Step 2: Install Visual Studio with Required Workloads
1. When the installer opens, select "Modify" if you have an existing installation, or "Install" for a new installation
2. In the workloads tab, select the following:
   - **Desktop development with C++**
     - Make sure all default components are selected
     - This includes:
       - MSVC v143 - VS 2022 C++ x64/x86 build tools
       - Windows 10/11 SDK (latest version)
       - CMake tools for C++
       - C++ profiling tools
       - C++ AddressSanitizer

### Step 3: Additional Components (Optional but Recommended)
- **.NET desktop development** (for additional tooling)
- **Git version control** (if not already installed)

### Step 4: Install
1. Click "Install" and wait for the installation to complete
2. This process may take 30-60 minutes depending on your internet connection

## Verification
After installation, you should be able to:
1. Open Visual Studio
2. Create a new C++ project
3. Build and run the project successfully

## Troubleshooting
### If you encounter issues:
1. Make sure Windows is updated to the latest version
2. Ensure you have enough disk space
3. Run the installer as Administrator
4. Check Windows Event Viewer for any error messages

## Next Steps
After Visual Studio installation is complete:
1. Restart your computer
2. Run `flutter doctor` to verify that the Visual Studio issue is resolved
3. Try building the Windows application with `flutter build windows`