"""Лабораторная работа № 1: подготовка аудио и извлечение MFCC.

Основа — функция preprocess_dataset из приложения методических указаний
«Распознавание речевых сигналов с помощью искусственной нейронной сети».
"""

import argparse
import json
from pathlib import Path

import librosa


PROJECT_DIR = Path(__file__).resolve().parent
DATASET_PATH = PROJECT_DIR / "dataset"
JSON_PATH = PROJECT_DIR / "data.json"
SAMPLE_RATE = 22050
SAMPLES_TO_CONSIDER = 22050  # Одна секунда аудио при 22050 Гц.


def preprocess_dataset(
    dataset_path: str | Path,
    json_path: str | Path,
    num_mfcc: int = 21,
    n_fft: int = 2048,
    hop_length: int = 512,
) -> dict:
    """Извлекает MFCC из WAV-файлов и записывает данные в JSON.

    Ожидается структура dataset/<название_класса>/*.wav.
    Выходные поля соответствуют методичке: mapping, labels, MFCCs, files.
    Короткие (менее одной секунды), пустые и повреждённые файлы пропускаются.
    """
    dataset_dir = Path(dataset_path).expanduser().resolve()
    output_file = Path(json_path).expanduser().resolve()

    if not dataset_dir.is_dir():
        raise FileNotFoundError(
            f"Папка с датасетом не найдена: {dataset_dir}. "
            "Поместите в неё каталоги bed, cat, happy."
        )
    if num_mfcc <= 0 or n_fft <= 0 or hop_length <= 0:
        raise ValueError("num_mfcc, n_fft и hop_length должны быть положительными")

    # Метки назначаются в алфавитном порядке, чтобы результат был повторяемым.
    class_dirs = sorted(
        (directory for directory in dataset_dir.iterdir() if directory.is_dir()),
        key=lambda directory: directory.name,
    )
    if not class_dirs:
        raise ValueError(f"В {dataset_dir} нет папок с классами аудиозаписей")

    data = {"mapping": [], "labels": [], "MFCCs": [], "files": []}
    skipped = 0

    for class_index, class_dir in enumerate(class_dirs):
        data["mapping"].append(class_dir.name)
        print(f"\nОбработка класса '{class_dir.name}' (метка {class_index})")
        wav_files = sorted(
            file for file in class_dir.iterdir()
            if file.is_file() and file.suffix.lower() == ".wav"
        )

        for file_path in wav_files:
            try:
                # librosa по умолчанию также использует 22050 Гц и моно.
                signal, sample_rate = librosa.load(
                    str(file_path), sr=SAMPLE_RATE, mono=True
                )
            except Exception as error:
                skipped += 1
                print(f"  Пропуск {file_path.name}: ошибка чтения ({error})")
                continue

            if len(signal) < SAMPLES_TO_CONSIDER:
                skipped += 1
                print(f"  Пропуск {file_path.name}: запись короче 1 секунды")
                continue

            signal = signal[:SAMPLES_TO_CONSIDER]
            mfcc = librosa.feature.mfcc(
                y=signal,
                sr=sample_rate,
                n_mfcc=num_mfcc,
                n_fft=n_fft,
                hop_length=hop_length,
            )

            # Вложенный список: [кадры по времени][коэффициенты MFCC].
            data["MFCCs"].append(mfcc.T.tolist())
            data["labels"].append(class_index)
            data["files"].append(file_path.relative_to(dataset_dir.parent).as_posix())
            print(f"  {file_path.name}: метка {class_index}")

    if not data["files"]:
        raise ValueError("Не найдено пригодных WAV-файлов длительностью от 1 секунды")

    output_file.parent.mkdir(parents=True, exist_ok=True)
    with output_file.open("w", encoding="utf-8") as file:
        json.dump(data, file, indent=4, ensure_ascii=False)

    print(f"\nОбработано: {len(data['files'])}; пропущено: {skipped}")
    print(f"Порядок классов: {data['mapping']}")
    print(f"Результат сохранён: {output_file}")
    return data


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Подготовка аудио (лабораторная № 1): WAV -> MFCC -> JSON"
    )
    parser.add_argument("--dataset", type=Path, default=DATASET_PATH)
    parser.add_argument("--output", type=Path, default=JSON_PATH)
    parser.add_argument("--num-mfcc", type=int, default=21)
    parser.add_argument("--n-fft", type=int, default=2048)
    parser.add_argument("--hop-length", type=int, default=512)
    args = parser.parse_args()
    preprocess_dataset(
        args.dataset,
        args.output,
        num_mfcc=args.num_mfcc,
        n_fft=args.n_fft,
        hop_length=args.hop_length,
    )


if __name__ == "__main__":
    main()
