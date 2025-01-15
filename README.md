# binf
## Dispay the description, homepage URL and version of a brew formula

## 💾 Installation

fisher install ltaupiac/brewinfo

Demo :

![demo](./demo.png)

### Usage
Usage: binf [options] <formula>

Dispay the description, homepage URL and version of a brew formula

Options:

-t, --trace : Verbose mode

-d, --debug : Show debugging information

-h, --help : Show this help message

-v, --version : Show version

### Informations displayed
**descrition**: Description of the formula
**homepage**  : The homepage of project
**version**   : Last version available
**installed** : Current version installed on the device, if available

### Abbr

An abbr is defined : **,bf**

### Dependencies

- jq    : Command-line JSON processor

## ©️ License

[MIT](LICENSE)
