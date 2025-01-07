# fringe-mode.nvim

TODO: Add video here

## Features

- Adds fringe (margin) to left and right of main windows
- Toggle on and off
- Fringe windows can't be navigated to from other windows
- Simple resize logic applied

## Limitations

- Doesn't work too well with left side tree

## Roadmap

1. Make fringe windows excluded from things like Ctrl-W o and opening a buffer in it
1. Fringe size calculation algorithm
   1. Auto-adjust fringe size based on how many vertical splits exist
   1. Uses `vim.o.columns` and window widths to calculate fringe widths
   1. Responsive when zooming in and out
1. Add options for configuration
   1. Window width (default: 80 and 120)
   1. Fringe background color
   1. Balance out windows on/off

## Inspiration

- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim)
- [centerpad.nvim](https://github.com/smithbm2316/centerpad.nvim)
- [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)
