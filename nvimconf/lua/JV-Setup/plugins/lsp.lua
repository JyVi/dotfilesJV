return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },
    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "clangd",
                "cmake",
                "rust_analyzer",
                "lua_ls",
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function ()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" }
                                }
                            }
                        }
                    }
                end,

                ["clangd"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.clangd.setup {
                        capabilities = capabilities,
                        cmd = {
                            "clangd",
                            "--background-index",
                            "--clang-tidy",
                            "--header-insertion=iwyu",
                            "--completion-style=detailed",
                            "--all-scopes-completion",
                            "--function-arg-placeholders",
                            "--fallback-style=llvm",
                            "--pretty",
                            -- "--std=c++20",
                        },
                        init_options = {
                            usePlaceholders = true,
                            completeUnimported = true,
                            clangdFileStatus = true,
                            -- take into account the c++20 and other, will 
                            -- have to put the flags on the compile files
                            fallbackFlags = {'--std=c++20'},
                        },
                        root_dir = function(fname)
                            return lspconfig.util.root_pattern(
                                "Makefile",
                                "configure.ac",
                                "configure.in",
                                "config.h.in",
                                "meson.build",
                                "meson_options.txt",
                                "build.ninja"
                            )(fname) or lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt")(fname) or lspconfig.util.find_git_ancestor(fname)
                        end,
                        on_attach = function(_, bufnr)
                            -- Function to add project includes when attaching to a buffer
                            local function add_project_includes()
                                local util = require("lspconfig/util")
                                local root_dir = util.root_pattern("compile_commands.json", ".git", "Makefile", "CMakeLists.txt")(vim.fn.getcwd())

                                if root_dir then
                                    -- Use the 'compile_commands.json' if available
                                    local compile_commands_path = root_dir .. "/compile_commands.json"
                                    if vim.fn.filereadable(compile_commands_path) == 1 then
                                        print("has compile_commands file")
                                        vim.lsp.buf_notify(bufnr, "workspace/didChangeConfiguration", {
                                            settings = {
                                                clangd = {
                                                    compilationDatabasePath = root_dir
                                                }
                                            }
                                        })
                                    else
                                        print("compile_commands file not found")
                                        -- If compile_commands.json is not found, add standard include paths manually
                                        vim.lsp.buf_notify(bufnr, "workspace/didChangeConfiguration", {
                                            settings = {
                                                clangd = {
                                                    includePath = {
                                                        "/usr/include",
                                                        "/usr/local/include",
                                                        "/usr/include/c++/v1", -- Add this line to include the standard C++ library headers
                                                        -- Add more paths if necessary
                                                    }
                                                }
                                            }
                                        })
                                    end
                                end
                            end

                            -- Call the function to add project includes
                            add_project_includes()
                        end
                    }
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                -- Accept currently selected item. 
                -- Set `select` to `false` to only confirm explicitly selected items.
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                    { name = 'buffer' },
                })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

    end
}
