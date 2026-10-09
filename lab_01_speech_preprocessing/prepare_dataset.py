import librosa
import os
import json


DATASET_PATH = os.path.join(os.path.dirname(__file__), "dataset")
JSON_PATH = os.path.join(os.path.dirname(__file__), "data.json")
SAMPLES_TO_CONSIDER = 22050


def preprocess_dataset(dataset_path, json_path, num_mfcc=21, n_fft=2048, hop_length=512):
    # Словарь для названий классов, меток, MFCC и имён файлов.
    data = {
        "mapping": [],
        "labels": [],
        "MFCCs": [],
        "files": []
    }

    # Обход папок датасета.
    for i, (dirpath, dirnames, filenames) in enumerate(os.walk(dataset_path)):
        if dirpath != dataset_path:
            label = os.path.basename(dirpath)
            data["mapping"].append(label)
            print("\nProcessing: '{}'".format(label))

            # Обработка аудиофайлов в каждой папке.
            for f in filenames:
                file_path = os.path.join(dirpath, f)
                signal, sample_rate = librosa.load(file_path)

                # Пропускаем записи короче одной секунды.
                if len(signal) >= SAMPLES_TO_CONSIDER:
                    signal = signal[:SAMPLES_TO_CONSIDER]

                    # Вычисление мел-частотных кепстральных коэффициентов.
                    MFCCs = librosa.feature.mfcc(
                        y=signal,
                        sr=sample_rate,
                        n_mfcc=num_mfcc,
                        n_fft=n_fft,
                        hop_length=hop_length
                    )

                    # Запись MFCC, метки класса и имени файла.
                    data["MFCCs"].append(MFCCs.T.tolist())
                    data["labels"].append(i - 1)
                    data["files"].append(file_path)
                    print("{}: {}".format(file_path, i - 1))

    # Сохранение обработанных данных в JSON.
    with open(json_path, "w") as fp:
        json.dump(data, fp, indent=4)


if __name__ == "__main__":
    preprocess_dataset(DATASET_PATH, JSON_PATH)
