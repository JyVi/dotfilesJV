" Set compatibility mode to enable Vim enhancements
set nocompatible

" Turn off filetype detection temporarily
filetype off

" Add Vundle to the runtime path and begin plugin management
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Add plugins for code completion
Plugin 'Valloric/YouCompleteMe'   " YCM Plugin
Plugin 'vim-airline/vim-airline'  " vim skin
Plugin 'vim-airline/vim-airline-themes' " vim theme skins
" End plugin management
call vundle#end()

" Enable filetype detection and plugin loading
filetype plugin indent on

set	noexpandtab
set tabstop=4
set shiftwidth=4
set mouse=a
set syntax=on
set number

filetype indent on 
