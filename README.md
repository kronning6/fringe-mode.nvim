# fringe-mode.nvim

TODO: Add video here

## Features

- Adds fringe (margin) to left and right of main windows
- Toggle on and off
- Fringe windows can't be navigated to from other windows

## Limitations

- Works alright with nvim-tree (and likely other nav trees) but bugs may exist

## Bugs

- Unknown

## Roadmap

1. On window close (e.g. ctrl-w o, ctrl-w c), resize windows
   1. Keep track of win_ids for fringe windows and row=1 windows
   1. Recreate fringe windows if they get closed, but mode is active
1. Resize fringe windows on resize of other windows
1. Improved window width calculations
   1. Auto-adjust fringe size based on how many vertical splits exist
   1. Capture window widths before resizes to keep proportions
      1. For horizontal splits, windows other than row=1 windows will also need to be tracked
   1. Uses `vim.o.columns` and window widths to calculate fringe widths
   1. Responsive when zooming in and out
1. Add configurable options
   1. Balance windows on mode activation or maintain width proportions
   1. Smart window width adjustments (prefer: 120 (default), narrow: 80 (default))
   1. Fringe background color (default to no background color)
   1. Add option to override ctrl-w o to provide a better UX that doesn't flicker
1. Remove border and padding between windows (visiable when fringe window bg color is changed)

## Inspiration

- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim)
- [centerpad.nvim](https://github.com/smithbm2316/centerpad.nvim)
- [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)
