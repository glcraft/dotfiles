-- set codeium value based on nushel's uname
vim.g.codeium_os = vim.trim(vim.fn.system({ "nu", "-c", "uname | get operating-system" }))
vim.g.codeium_arch = vim.trim(vim.fn.system({ "nu", "-c", "uname | get machine" }))

vim.g.DELTA_OPTIONS = "-s"

vim.filetype.add({
  extension = {
    vsh = 'glsl',
    fsh = 'glsl',
    gsh = 'glsl',
  }
})

-- local pickers = require "telescope.pickers"
-- local finders = require "telescope.finders"
-- local conf = require("telescope.config").values
--
-- vim.api.nvim_create_user_command("DocSym", function()
--   -- vim.notify("hello")
--   vim.lsp.buf.document_symbol({
--     on_list = function(opts)
--       local results = {}
--       for _,f in ipairs(opts.items) do
--         table.insert(results, f.filename .. ":" .. f.lnum .. ":" .. f.col)
--       end
--
--
--       pickers.new({}, {
--         prompt_title = "Document Symbols",
--         finder = finders.new_table {
--           results = results
--         },
--         sorter = conf.generic_sorter({}),
--       }):find()
--     end
--   })
-- end, {})

-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function()
--     vim.g.FRAMETERM_ISDIR = vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv()[1]) == 1
--     if vim.g.FRAMETERM_ISDIR then
--       local session_path = vim.fn.getcwd() .. '/.nvim/Session.vim'
--       if ( vim.fn.filereadable(session_path) == 1 ) then
--         vim.cmd("source " .. session_path) 
--       else
--         vim.cmd("NvimTreeToggle")
--       end
--     end
--   end
-- })
--
-- vim.api.nvim_create_user_command("SaveSession", function()
--   local dir = vim.fn.getcwd() .. '/.nvim'
--     if not ( vim.fn.isdirectory(dir) == 1 ) then
--       vim.fn.mkdir(dir, "p")
--     end
--     vim.cmd("mksession! ".. dir .. "/Session.vim")
-- end, {})
--
-- vim.api.nvim_create_autocmd('VimLeave', {
--   callback = function()
--     if not vim.g.FRAMETERM_ISDIR then
--       return false
--     end
--
--     vim.cmd("SaveSession")
--   end
-- })
