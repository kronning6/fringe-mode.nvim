# fringe-mode.nvim

fringe-mode.nvim is a simple nvim plugin to add margin (fringe) to
the left and right of your buffers.

TODO: Add a video here to show fringe-mode.nvim in action.

## Features

- Adds fringe (margin) to left and right of main windows
- Toggle on and off
- Fringe windows can't be navigated to from other windows
- Recreate fringe windows if they get closed, but mode is active
- Ability to set bg color for fringe windows

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
   'kronning6/fringe-mode.nvim',
   config = function()
      require('fringe-mode').setup({
         -- options (see below)
      })
   end,
},
```

## Configuration

Defaults:

```lua
{
   balance_windows = false, -- Optionally call ctrl-w = before sizing fringe windows
   bgcolor = nil, -- Set the background color for the fringe windows
   min_fringe_window_width = 10, -- If fringe window is less than 10 cols, use narrow widths
   widths = { -- Add 8 cols to account for git signs and line numbers
      normal = 128, -- More modern max code width
      narrow = 88, -- Standard max code width
   }
}
```

## Limitations

- Works alright with nvim-tree (and likely other nav trees) but may be a little buggy

## Bugs

- Unknown

## Tasks

1. Keep track of win_ids and widths of fringe windows and row=1 windows

## Roadmap

1. On window close (e.g. ctrl-w o, ctrl-w c), resize windows
1. Resize fringe windows on resize of other windows
1. Improved window width calculations
   1. Capture window widths before resizes to keep proportions
      1. Uses `vim.o.columns` and window widths to calculate fringe widths
      1. For horizontal splits, windows other than row=1 windows will also need to be tracked
   1. Responsive when zooming in and out
1. Add configurable options
   1. Balance windows on mode activation or maintain width proportions
   1. Add option to override ctrl-w o to provide a better UX that doesn't flicker
1. Remove border and padding between windows (visible when fringe window bg color is changed)

## Inspiration

- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim)
- [centerpad.nvim](https://github.com/smithbm2316/centerpad.nvim)
- [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)
