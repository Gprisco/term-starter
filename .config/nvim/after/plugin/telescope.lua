require('telescope').setup({
    defaults = {
        vimgrep_arguments = {
            'rg',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--glob=!.git/*',
            '--hidden',
        },
    }
})

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind [G]rep' })
vim.keymap.set('n', '<leader>mfg', function()
    local user_input = vim.fn.input('File mask: ')
    builtin.live_grep({ glob_pattern = user_input })
end, { desc = '[M]ask [F]ile [G]rep' })
