import tensorflow as tf 
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras import regularizers, optimizers
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score


class ANNModel(object):

    def __init__(self, x_train, y_train):
        """Creates a model that can predict new data.

        Args:
            x_train: The training data.
            y_train: The training labels.

        """

        self.model = Sequential()
        self.model.add(Dense(units=256, activation='relu', input_shape=(x_train.shape[1],)))
        self.model.add(Dropout(0.2))
        self.model.add(Dense(units=128, activation='relu', kernel_regularizer=regularizers.l2(0.02)))
        self.model.add(Dense(units=64, activation='relu', kernel_regularizer=regularizers.l2(0.02)))
        self.model.add(Dense(units=32, return_sequences=False))
        self.model.add(Dropout(0.2))
        self.model.add(Dense(units=y_train.shape[1], activation='linear'))

        # Compile the model
        optimizer = optimizers.Adam(learning_rate=0.0010)
        self.model.compile(loss='mean_squared_error', optimizer=optimizer)

    def fit(self, x_train, y_train, epochs=100, batch_size=8, validation_data=None):
        """Trains the model on a dataset of training data.

        Args:
            x_train: The training data.
            y_train: The training labels.
            epochs: The number of epochs to train for.
            batch_size: The batch size to use.
            validation_data: The validation data to use.

        """

        self.model.fit(x_train, y_train, epochs=epochs, batch_size=batch_size, validation_data=validation_data)

    def predict(self, x_test):
        """Predicts new data.

        Args:
            x_test: The test data.

        Returns:
            A NumPy array of predictions.

        """

        return self.model.predict(x_test)


def main():

    # Load the data
    df = pd.read_csv(r'D:\Tesis SUT\Data\df.csv')

    # Split the data into training and test sets
    x_train, x_test, y_train, y_test = train_test_split(df, df['y'], test_size=0.25)

    # Create the model
    model = ANNModel(x_train, y_train)

    # Train the model
    model.fit(x_train, y_train, epochs=100, batch_size=8)

    # Predict new data
    predictions = model.predict(x_test)

    # Evaluate the model
    mse_test = model.evaluate(x_test, y_test, verbose=0)
    print(f'MSE on test set: {mse_test:.4f}')

    # Forecast
    forecast = model.predict(x_all)

    # Save the forecast
    new_column = list(range(60))
    proc[19] = new_column
    proc[i] = pd.DataFrame(forecast)
    proc = proc.iloc[:, :-1]
    proc.to_csv(r'D:\Tesis SUT\Results\ANN\hat_y.csv', index = False, header=False)

    print(proc)


if __name__ == '__main__':
    main()