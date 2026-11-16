# Class merger benchmark

Workload is 20 pages. Each page renders Card, Icon, Button, and Badge 25 times, with a repeated class override (`mt-2 px-2`, `mt-4 px-4`, or `mt-1 p-2`). That is 2,000 component renders per sample. Five samples. `GC.start` runs before each sample. The same script counted `TailwindMerge::Merger.new`.

Ruby 3.3.13. `tailwind_merge` 1.5.6. Postgres was up for the dummy boot and was not on the timed path.

Re-run from the repo root:

```bash
bundle exec ruby docs/review/class_merger_benchmark.rb
```

## Before, Flatpack 0.1.376

Each sample constructed a merger 5,000 times.

| Sample | Seconds | `Merger.new` |
| --- | ---: | ---: |
| 1 | 7.7123 | 5000 |
| 2 | 8.2863 | 5000 |
| 3 | 7.6044 | 5000 |
| 4 | 7.4788 | 5000 |
| 5 | 7.6085 | 5000 |

Median 7.6085 seconds. Min 7.4788. Max 8.2863.

A fresh merger, 200 merges of one class string, took 0.2745 seconds. One reused merger, 2,000 unique strings, took 0.0326 seconds. The same string 2,000 times took 0.0006 seconds.

## After, Flatpack 0.1.377

Each sample constructed a merger 0 times. The warmup render before the samples built the one shared merger. These numbers are from `docs/review/class_merger_benchmark.rb`.

| Sample | Seconds | `Merger.new` |
| --- | ---: | ---: |
| 1 | 0.0609 | 0 |
| 2 | 0.0415 | 0 |
| 3 | 0.0413 | 0 |
| 4 | 0.0417 | 0 |
| 5 | 0.0413 | 0 |

Median 0.0415 seconds. Min 0.0413. Max 0.0609. An earlier run of the same script on this machine had median 0.0378 seconds.

The fresh-merger control stayed in the same range, 0.2384 seconds for 200 merges. One reused merger, 2,000 unique strings, took 0.0536 seconds. The same string 2,000 times took 0.0005 seconds.

## Delta

The page median dropped from 7.6085 seconds to 0.0415 seconds. That is 183 times faster on this run, and 201 times faster on the 0.0378 second run. The before samples each called `Merger.new` 5,000 times. The after samples call it 0 times. A fresh merger still costs about 1.2 to 1.4 milliseconds, so those 5,000 constructions account for most of the time.

Rendered HTML for one Card, Icon, Button, and Badge, each with `class: "mt-2 px-2"`, matched byte for byte before and after.
