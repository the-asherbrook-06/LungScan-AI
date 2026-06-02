from torch.utils.data import Dataset
from PIL import Image
import numpy as np
import torch
import os


class ChestXrayDataset(Dataset):

    def __init__(self, dataframe, image_dir, label_cols, transform=None):
        self.df = dataframe.reset_index(drop=True)
        self.image_dir = image_dir
        self.label_cols = label_cols
        self.transform = transform

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        img_path = os.path.join(self.image_dir, row["Image Index"])
        image = Image.open(img_path).convert("RGB")

        if self.transform:
            image = self.transform(image)
        labels = torch.tensor(
            row[self.label_cols].values.astype(np.float32)
        )

        return image, labels