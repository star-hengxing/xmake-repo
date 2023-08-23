package("rsm-bsa")
    set_homepage("https://github.com/Ryan-rsm-McKenzie/bsa")
    set_description("C++ library for working with the Bethesda archive file format")
    set_license("MIT")

    add_urls("https://github.com/Ryan-rsm-McKenzie/bsa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Ryan-rsm-McKenzie/bsa.git")

    add_versions("4.0.3", "d77729c08c0a383727eef14fc0612286269b960373bbc91b8625688d6be73fbf")

    add_configs("xmem", {description = "build support for the xmem codec proxy", default = false, type = "boolean", readonly = true})

    add_deps("rsm-mmio", "rsm-binary-io", "lz4", "zlib")
    if is_plat("windows") then
        add_deps("directxtex")
        add_syslinks("ole32")
    end

    on_load(function (package)
        if package:config("xmem") then
            package:add("defines", "BSA_SUPPORT_XMEM=1")
            package:add("deps", "reproc", "expected-lite", "xbyak")
            package:add("deps", "rsm-mmio~32", "rsm-binary-io~32")
            package:add("deps", "expected-lite~32", "xbyak~32", "taywee_args~32")
        end
    end)

    on_install("windows", "linux", function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local configs = {}
        configs.ver = package:version_str()
        if package:config("xmem") then
            configs.xmem = true
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bsa/tes4.hpp>
            void test() {
                const char payload[] = { "Hello world!\n" };
                bsa::tes4::file f;
                f.set_data({ reinterpret_cast<const std::byte*>(payload), sizeof(payload) - 1 });
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
