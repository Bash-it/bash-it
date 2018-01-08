## Testing with [Bats](https://github.com/sstephenson/bats#installing-bats-from-source)

To execute the unit tests, please run the `run` script:

```bash
# If you are in the `test` directory:
./run

# If you are in the root `.bash_it` directory:
test/run
```

The `run` script will automatically install [Bats](https://github.com/sstephenson/bats#installing-bats-from-source) if it is not already present, and will then run all tests found under the `test` directory, including subdirectories.
