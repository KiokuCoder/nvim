-- ~/.config/nvim/init.lua
-- 纯内置配置：不使用任何插件管理器，不从网络下载任何内容
-- 适用于 Neovim 0.10+

---------------------------------------------------------------------------
-- 基础
---------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 关闭 Python/Ruby/Perl/Node 的远程插件 provider：用不上，也少一些外部依赖
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

local opt = vim.opt

---------------------------------------------------------------------------
-- 安全相关
---------------------------------------------------------------------------
opt.modeline = false -- 不执行文件中的 modeline（历史上出现过任意代码执行漏洞）
opt.exrc = false     -- 不自动加载当前目录下的 .nvim.lua / .exrc
opt.undofile = false -- 不把撤销历史持久化到磁盘（撤销文件里含有文件内容）

---------------------------------------------------------------------------
-- 界面
---------------------------------------------------------------------------
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.termguicolors = true
opt.mouse = "a"
opt.splitright = true
opt.splitbelow = true
opt.laststatus = 3
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.statusline = " %f %m%r%h%w%=%y  %{&fenc!=''?&fenc:&enc}  %{&ff}  %l:%c  %p%% "

---------------------------------------------------------------------------
-- 缩进
---------------------------------------------------------------------------
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.shiftround = true
opt.smartindent = true

---------------------------------------------------------------------------
-- 搜索
---------------------------------------------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split" -- :s 替换时实时预览

---------------------------------------------------------------------------
-- 编辑
---------------------------------------------------------------------------
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true -- 未保存就退出时询问，而不是直接报错
opt.completeopt = { "menuone", "noselect" }
opt.wildmode = "longest:full,full"
opt.fileencodings = "ucs-bom,utf-8,gb18030,latin1" -- 能正确打开 GBK 编码的文件

---------------------------------------------------------------------------
-- 内置文件浏览器 netrw
---------------------------------------------------------------------------
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25

---------------------------------------------------------------------------
-- 快捷键
---------------------------------------------------------------------------
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "清除搜索高亮" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "保存" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "退出" })
map("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "文件浏览器" })
map("n", "<leader>b", ":ls<CR>:buffer ", { desc = "切换 buffer" })

-- 窗口间移动
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- 可视模式下缩进后保持选中
map("v", "<", "<gv")
map("v", ">", ">gv")

-- 可视模式下上下移动选中的行
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- 搜索跳转时让结果居中
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- 内置终端中按两次 Esc 回到普通模式
map("t", "<Esc><Esc>", [[<C-\><C-n>]])

---------------------------------------------------------------------------
-- 自动命令
---------------------------------------------------------------------------
local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- 复制时短暂高亮被复制的内容
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 200 })
  end,
})

-- 重新打开文件时回到上次的光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 按文件类型调整缩进
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "lua", "yaml", "json", "html", "css", "javascript", "typescript", "nix" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "go", "make" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

---------------------------------------------------------------------------
-- 自定义命令
---------------------------------------------------------------------------
-- :TrimWhitespace 删除行尾空白（手动执行，避免自动改动造成无关的 diff）
vim.api.nvim_create_user_command("TrimWhitespace", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, {})
