"""Резервирование WAV-файлов для лабораторной работы № 3.

По шагу 3 лабораторной № 1 отдельные записи нужно убрать из обучающего
датасета и сохранить для финального тестирования. Этот скрипт перемещает
записи только после явного запуска без --dry-run.
"""

import argparse
import random
import shutil
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent


def reserve_samples(
    dataset_dir: Path,
    test_dir: Path,
    per_class: int = 10,
    seed: int = 42,
    dry_run: bool = False,
) -> list[tuple[Path, Path]]:
    dataset_dir = dataset_dir.expanduser().resolve()
    test_dir = test_dir.expanduser().resolve()
    if not dataset_dir.is_dir():
        raise FileNotFoundError(f"Датасет не найден: {dataset_dir}")
    if per_class <= 0:
        raise ValueError("--per-class должен быть больше 0")
    if test_dir == dataset_dir or dataset_dir in test_dir.parents:
        raise ValueError("Папка для тестовых записей должна быть вне dataset")

    folders = sorted(path for path in dataset_dir.iterdir() if path.is_dir())
    if not folders:
        raise ValueError("Нет папок классов в датасете")

    rng = random.Random(seed)
    planned: list[tuple[Path, Path]] = []
    for folder in folders:
        wav_files = sorted(
            path for path in folder.iterdir()
            if path.is_file() and path.suffix.lower() == ".wav"
        )
        if len(wav_files) <= per_class:
            raise ValueError(
                f"В классе '{folder.name}' всего {len(wav_files)} WAV-файлов; "
                f"нужно больше {per_class}, чтобы остались обучающие записи"
            )
        for source in rng.sample(wav_files, per_class):
            destination = test_dir / folder.name / source.name
            if destination.exists():
                raise FileExistsError(f"Файл уже существует: {destination}")
            planned.append((source, destination))

    for source, destination in planned:
        print(f"{'Будет перемещён' if dry_run else 'Перемещение'}: "
              f"{source} -> {destination}")
        if not dry_run:
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(source), str(destination))

    print(f"Всего выбранных файлов: {len(planned)}")
    return planned


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Выделить записи из dataset для финального тестирования"
    )
    parser.add_argument("--dataset", type=Path, default=PROJECT_DIR / "dataset")
    parser.add_argument("--target", type=Path, default=PROJECT_DIR / "test_audio")
    parser.add_argument("--per-class", type=int, default=10)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    reserve_samples(args.dataset, args.target, args.per_class, args.seed, args.dry_run)


if __name__ == "__main__":
    main()
