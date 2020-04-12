# cite 'uuid-alias'
# about-alias 'uuidgen aliases'

if [ "$(uuid 2>/dev/null)" != "" ]; then # Linux
  alias uuidu="uuid | tr '[:lower:]' '[:upper:]'"
  alias uuidl=uuid
elif [ "$(uuidgen 2>/dev/null)" != "" ]; then # macOS/BSD
  alias uuidu="uuidgen"
  alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'" # because upper case is like YELLING
  alias uuidl=uuid
fi
