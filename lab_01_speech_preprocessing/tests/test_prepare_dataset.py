"""Небольшие тесты без преподавательского датасета."""

import json
import sys
from pathlib import Path

import numpy as np
import pytest
import soundfile as sf

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from prepare_dataset import preprocess_dataset  # noqa: E402
from reserve_test_samples import reserve_samples  # noqa: E402


def write_audio(path: Path, samples: int = 22050) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    t = np.arange(samples) / 22050
    sf.write(path, 0.2 * np.sin(2 * np.pi * 440 * t), 22050)


def test_prepare_json_mapping_and_mfcc(tmp_path: Path) -> None:
    dataset = tmp_path / "dataset"
    write_audio(dataset / "happy" / "2.wav", 23000)
    write_audio(dataset / "bed" / "1.wav", 22050)
    write_audio(dataset / "cat" / "too_short.wav", 1000)
    write_audio(dataset / "cat" / "valid.wav", 22050)

    output = tmp_path / "data.json"
    data = preprocess_dataset(dataset, output, num_mfcc=13)
    saved = json.loads(output.read_text(encoding="utf-8"))

    assert saved == data
    assert data["mapping"] == ["bed", "cat", "happy"]
    assert data["labels"] == [0, 1, 2]
    assert len(data["MFCCs"]) == len(data["files"]) == 3
    assert all(len(record) == 44 for record in data["MFCCs"])
    assert all(len(record[0]) == 13 for record in data["MFCCs"])
    assert data["files"] == [
        "dataset/bed/1.wav", "dataset/cat/valid.wav", "dataset/happy/2.wav"
    ]


def test_dataset_not_found(tmp_path: Path) -> None:
    with pytest.raises(FileNotFoundError):
        preprocess_dataset(tmp_path / "missing", tmp_path / "data.json")


def test_reserve_dry_run_does_not_move_files(tmp_path: Path) -> None:
    dataset = tmp_path / "dataset"
    for label in ("bed", "cat", "happy"):
        write_audio(dataset / label / "a.wav")
        write_audio(dataset / label / "b.wav")
    moves = reserve_samples(dataset, tmp_path / "test_audio", per_class=1, dry_run=True)
    assert len(moves) == 3
    assert all(src.exists() and not dst.exists() for src, dst in moves)


def test_reserve_moves_only_selected(tmp_path: Path) -> None:
    dataset = tmp_path / "dataset"
    for label in ("bed", "cat", "happy"):
        write_audio(dataset / label / "a.wav")
        write_audio(dataset / label / "b.wav")
    moves = reserve_samples(dataset, tmp_path / "test_audio", per_class=1)
    assert len(moves) == 3
    assert all(not src.exists() and dst.exists() for src, dst in moves)
    assert all(len(list((dataset / label).glob("*.wav"))) == 1 for label in ("bed", "cat", "happy"))
