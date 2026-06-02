import torch.nn as nn
import torchvision.models as models

def get_model(num_classes):
    model = models.densenet121(weights=None)  # no need to download weights again
    
    num_features = model.classifier.in_features
    model.classifier = nn.Linear(num_features, num_classes)
    
    return model