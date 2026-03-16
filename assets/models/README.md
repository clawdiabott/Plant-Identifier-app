Place your TensorFlow Lite models in this directory:

- `plant_species_model.tflite` (MobileNet-like classifier fine-tuned on PlantNet/iNaturalist)
- `disease_detector_model.tflite` (PlantVillage-based disease/nutrient deficiency model)

Expected input:
- shape: `[1, 224, 224, 3]`
- normalization: float32 in range `[0, 1]`

Recommended resources:
- PlantVillage dataset: https://www.kaggle.com/datasets/emmarex/plantdisease
- iNaturalist: https://www.inaturalist.org/pages/developers
- PlantNet: https://plantnet.org
