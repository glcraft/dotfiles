-- set codeium value based on nushel's uname
vim.g.codeium_os = vim.trim(vim.fn.system({ "nu", "-c", "uname | get operating-system" }))
vim.g.codeium_arch = vim.trim(vim.fn.system({ "nu", "-c", "uname | get machine" }))
