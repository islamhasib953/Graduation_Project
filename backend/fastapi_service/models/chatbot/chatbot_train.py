import json
import pickle
import numpy as np
import nltk
from nltk.stem import WordNetLemmatizer
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, BatchNormalization
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from tensorflow.keras.optimizers import Adam
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

# Download required NLTK data
nltk.download('punkt')
nltk.download('wordnet')
nltk.download('punkt_tab')

# Initialize lemmatizer
lemmatizer = WordNetLemmatizer()

# Load intents file
with open('backend/fastapi_service/intents_cleaned.json') as file:
    intents = json.load(file)

# Initialize lists
words = []
classes = []
documents = []
ignore_words = ['?', '!', '.', ',', ':', ';', '(', ')', '[', ']', '{', '}']

# Process intents
for intent in intents['intents']:
    for pattern in intent['patterns']:
        # Tokenize each word
        word_list = nltk.word_tokenize(pattern)
        words.extend(word_list)
        # Add to documents
        documents.append((word_list, intent['tag']))
        # Add to classes if not already present
        if intent['tag'] not in classes:
            classes.append(intent['tag'])

# Lemmatize and remove duplicates
words = [lemmatizer.lemmatize(w.lower())
         for w in words if w not in ignore_words]
words = sorted(list(set(words)))
classes = sorted(list(set(classes)))

# Save words and classes
pickle.dump(words, open('words-c.pkl', 'wb'))
pickle.dump(classes, open('classes-c.pkl', 'wb'))

# Create training data
training = []
output_empty = [0] * len(classes)

for doc in documents:
    bag = []
    pattern_words = doc[0]
    pattern_words = [lemmatizer.lemmatize(
        word.lower()) for word in pattern_words]

    # Create bag of words
    for w in words:
        bag.append(1) if w in pattern_words else bag.append(0)

    # Output is a '0' for each tag and '1' for current tag
    output_row = list(output_empty)
    output_row[classes.index(doc[1])] = 1

    training.append([bag, output_row])

# Shuffle and convert to numpy array
np.random.shuffle(training)
training = np.array(training, dtype=object)

train_x = np.array(list(training[:, 0]))
train_y = np.array(list(training[:, 1]))

# Split data into training and testing sets
train_x, test_x, train_y, test_y = train_test_split(
    train_x, train_y, test_size=0.2, random_state=42)

# Build the model
model = Sequential()
model.add(Dense(256, input_shape=(len(train_x[0]),), activation='relu'))
model.add(BatchNormalization())
model.add(Dropout(0.3))
model.add(Dense(128, activation='relu'))
model.add(BatchNormalization())
model.add(Dropout(0.3))
model.add(Dense(64, activation='relu'))
model.add(BatchNormalization())
model.add(Dropout(0.3))
model.add(Dense(len(train_y[0]), activation='softmax'))

# Compile the model
model.compile(loss='categorical_crossentropy', optimizer=Adam(
    learning_rate=0.001), metrics=['accuracy'])

# Callbacks
early_stopping = EarlyStopping(
    monitor='val_loss', patience=10, restore_best_weights=True)
lr_scheduler = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5)

# Train the model
history = model.fit(train_x, train_y, epochs=300, batch_size=4, verbose=1, validation_split=0.2,
                    callbacks=[early_stopping, lr_scheduler])

# Save the model
model.save('chatbot_model-c.h5')

# Evaluate the model on the test set
test_predictions = model.predict(test_x)
test_predictions = np.argmax(test_predictions, axis=1)
test_y_labels = np.argmax(test_y, axis=1)

# Calculate metrics
accuracy = accuracy_score(test_y_labels, test_predictions)
precision, recall, f1, _ = precision_recall_fscore_support(
    test_y_labels, test_predictions, average='weighted')

# Generate confusion matrix
conf_matrix = confusion_matrix(test_y_labels, test_predictions)

# Save evaluation report to a text file
with open('model_performance_report.txt', 'w') as f:
    f.write("Model Performance Report\n")
    f.write("=======================\n")
    f.write(f"Accuracy: {accuracy:.4f}\n")
    f.write(f"Precision: {precision:.4f}\n")
    f.write(f"Recall: {recall:.4f}\n")
    f.write(f"F1-Score: {f1:.4f}\n")
    f.write("\nConfusion Matrix:\n")
    f.write(f"{conf_matrix}\n")
    f.write("\nClass Names (in order):\n")
    f.write(f"{classes}\n")

# Plot confusion matrix
plt.figure(figsize=(10, 8))
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues',
            xticklabels=classes, yticklabels=classes)
plt.title('Confusion Matrix')
plt.xlabel('Predicted')
plt.ylabel('True')
plt.savefig('confusion_matrix.png')

# Plot training history
plt.figure(figsize=(12, 4))

# Plot accuracy
plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'], label='Train Accuracy')
plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
plt.title('Model Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.legend()

# Plot loss
plt.subplot(1, 2, 2)
plt.plot(history.history['loss'], label='Train Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.title('Model Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()

plt.tight_layout()
plt.savefig('training_history.png')

print("Model training completed and saved as 'chatbot_model-c.h5'")
print("Performance report saved as 'model_performance_report.txt'")
print("Confusion matrix saved as 'confusion_matrix.png'")
print("Training history plot saved as 'training_history.png'")
