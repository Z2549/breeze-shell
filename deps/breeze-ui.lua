package("breeze-glfw")
    set_base("glfw")
    set_urls("https://github.com/breeze-shell/glfw.git")
    add_versions("2026.03.07+1", "a79c32a7d9ef4cd8a15b5f8ccbcdf9510c48da03")

local BREEZE_UI_VER = "2026.04.12"
local BREEZE_UI_HASH = "8dce69e41f3080e0ec610c93f56fa9a1606a7baf"
local BREEZE_UI_LOCAL_PATH = path.join(os.scriptdir(), "..", "..", "breeze-ui")
local USE_LOCAL_BREEZE_UI = os.exists(BREEZE_UI_LOCAL_PATH)

-- BUILD FIX (not part of the upstream PR): breeze-ui's xmake.lua has an unpinned
-- `add_requires("glad")`, and xmake-repo now also ships glad v2.0.8. glad 2.x only
-- provides <glad/gl.h>, while breeze_ui/nanovg_wrapper.h includes the 0.x layout
-- <glad/glad.h>, so every package below that runs a nested xmake build of the
-- whole breeze-ui project fails with: fatal error: 'glad/glad.h' file not found.
-- This patch pins the requirement back to 0.1.36 (the version breeze-shell itself
-- already pins in its root xmake.lua).
local BREEZE_UI_GLAD_PATCH = path.join(os.scriptdir(), "patches", "breeze-ui-pin-glad-0.1.36.patch")
local BREEZE_UI_GLAD_PATCH_SHA256 = "6a2965eff8bf355edf46b0b788a3fe5c4f5af5fa1eed5fdd99c6b094a4adc653"

package("breeze-nanosvg")
    if USE_LOCAL_BREEZE_UI then
        set_sourcedir(BREEZE_UI_LOCAL_PATH)
    else
        add_urls("https://github.com/std-microblock/breeze-ui.git")
        add_versions(BREEZE_UI_VER, BREEZE_UI_HASH)
        add_patches(BREEZE_UI_VER, BREEZE_UI_GLAD_PATCH, BREEZE_UI_GLAD_PATCH_SHA256)
    end

    set_kind("library", {headeronly = true})
    set_description("The breeze-nanosvg package")

    add_deps("glad 0.1.36")

    on_install("windows", function (package)
        import("package.tools.xmake").install(package)
    end)

package("breeze-nanovg")
    if USE_LOCAL_BREEZE_UI then
        set_sourcedir(BREEZE_UI_LOCAL_PATH)
    else
        add_urls("https://github.com/std-microblock/breeze-ui.git")
        add_versions(BREEZE_UI_VER, BREEZE_UI_HASH)
        add_patches(BREEZE_UI_VER, BREEZE_UI_GLAD_PATCH, BREEZE_UI_GLAD_PATCH_SHA256)
    end

    set_description("The breeze-nanovg package")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("glad 0.1.36")

    on_install("windows", function (package)
        import("package.tools.xmake").install(package)
    end)


package("breeze-ui")
    if USE_LOCAL_BREEZE_UI then
        set_sourcedir(BREEZE_UI_LOCAL_PATH)
    else
        add_urls("https://github.com/std-microblock/breeze-ui.git")
        add_versions(BREEZE_UI_VER, BREEZE_UI_HASH)
        add_patches(BREEZE_UI_VER, BREEZE_UI_GLAD_PATCH, BREEZE_UI_GLAD_PATCH_SHA256)
    end
    add_deps("breeze-glfw", "glad 0.1.36", "nanovg", "breeze-nanosvg", "simdutf", {
        public = true
    })
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("windows") then
        add_syslinks("dwmapi", "imm32", "shcore", "windowsapp", "CoreMessaging")
    end

    on_install("windows", function (package)
        import("package.tools.xmake").install(package)
    end)
