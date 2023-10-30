# Bash Completion for Atom Package Manager (apm)

If you use [Atom](http://atom.io) editor, you'll like this completion helper.

## Installation

You can install via [Homebrew](http://brew.sh)

    brew install homebrew/completions/apm-bash-completion

## Usage

```bash
$ apm [TAB]

clean                 featured              ln                    remove                unlink
config                help                  lns                   rm                    unpublish
dedupe                home                  login                 search                unstar
deinstall             init                  ls                    show                  update
delete                install               open                  star                  upgrade
dev                   link                  outdated              starred               view
develop               linked                publish               stars                 
docs                  links                 rebuild               test                  
erase                 list                  rebuild-module-cache  uninstall             

$ apm publish
build  major  minor  patch

$ apm config
delete  edit    get     list    set
```

## Manual Usage

Just get the file `apm` and call `source apm` (or add it to your bash environment)

---

## What’s New?

Well, I even don’t remember this project since I’ve got mail today about
missing LICENSE file. Feel free to contribute, add missing pieces :)

---

## Contribution

Please let me know if you need some more options. Please create an issue and
make a request. Also If you like to improve or add more features please fork
it and you know the rest :)

1. Fork it ( https://github.com/vigo/apm-bash-completion )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

---

## Contributer(s)

* [Uğur "vigo" Özyılmazel](https://github.com/vigo) - Creator, maintainer

---

## License

This project is licensed under MIT

---
