---
name: dart-cli-app
description: Structure, test, and compile a Dart command-line application — entrypoints, subcommands, exit codes, and native executables. Use when building a CLI tool or script in Dart.
---

# Dart CLI Applications

Language-level rules (types, null safety, error handling) come from the `dart-core` rule. This covers the CLI-specific shape.

## Layout

`dart create -t cli <name>` scaffolds it. Then:

- `bin/` holds only entrypoints — files with `main()`.
- `lib/src/` holds implementation; `lib/<name>.dart` exports the public surface.

Keeping logic out of `bin/` is what makes it testable without spawning a process.

## Arguments

Use `package:args`. For a single-purpose script, `ArgParser` with `addFlag`/`addOption` directly. For a multi-command tool, `CommandRunner` plus one `Command` subclass per subcommand:

```dart
class CommitCommand extends Command {
  @override final String name = 'commit';
  @override final String description = 'Record changes to the repository.';

  CommitCommand() {
    argParser.addFlag('all', abbr: 'a', help: 'Commit all changed files.');
  }

  @override
  Future<void> run() async { /* ... */ }
}
```

Global flags go on `CommandRunner.argParser`, command-specific flags on the command's own `argParser`.

Help text is part of the interface. If it names a compiled executable, say how to get it on `PATH` — otherwise the help describes an invocation the user cannot perform.

## Exit codes and errors

```dart
void main(List<String> args) {
  Chain.capture(() async {
    final runner = CommandRunner('dgit', 'Distributed version control.')
      ..addCommand(CommitCommand());
    await runner.run(args);
  }, onError: (error, chain) {
    if (error is UsageException) {
      stderr..writeln(error.message)..writeln(error.usage);
      exit(64);                       // ExitCode.usage.code
    }
    stderr..writeln('Fatal error: $error')..writeln(chain.terse);
    exit(1);
  });
}
```

- `ExitCode` from `package:io` for POSIX-standard codes rather than bare integers.
- `Chain.capture` from `package:stack_trace` preserves async stack chains; `chain.terse` strips core-library frames before the user sees them.
- Errors go to `stderr` with a non-zero exit. A failure that prints to stdout and exits 0 is invisible to every caller and every CI step.
- `sharedStdIn` from `package:io` when several async listeners need sequential stdin access.

## Testing

Logic in `lib/src/` gets ordinary unit tests. The CLI surface — argument handling, output, exit codes, file effects — needs `test_process` and `test_descriptor`:

```dart
await d.dir('project', [d.file('config.json', '{"key": "value"}')]).create();

final process = await TestProcess.start(
  'dart', ['run', 'bin/cli.dart', 'process', '--path', '${d.sandbox}/project']);

await expectLater(process.stdout, emitsThrough('Processing complete.'));
await process.shouldExit(0);

await d.dir('project', [d.file('output.log', 'Success')]).validate();
```

Every new command needs automated coverage. Help text and overall UX still need a manual look — tests confirm it works, not that it reads well.

## Compiling

- `dart run bin/cli.dart` — JIT, for development.
- `dart compile exe bin/cli.dart -o build/cli` — standalone native executable, runtime bundled.
- `dart compile aot-snapshot bin/cli.dart` — smaller; runs via `dartaotruntime`. Use when shipping many tools together.
- `dart build cli` — when the tool has build hooks or bundles code assets; outputs to `build/cli/_/bundle/`.

Cross-compilation targets Linux only, from any host: `--target-os=linux` with `--target-arch=` one of `x64`, `arm64`, `arm`, `riscv64`.

Before releasing: `dart format . --set-exit-if-changed`, `dart analyze`, `dart test`, then compile and run the actual executable — JIT and AOT differ in ways that only surface at runtime.
