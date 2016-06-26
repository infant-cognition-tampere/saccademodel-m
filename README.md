# Saccade Model for MATLAB

This package contains MATLAB implementation of saccade model, an algorithm to recognize a good single saccade from a set of points. This implementation was later on converted and developed further in Python. The python version and further details of the functioning of the model are available at [github.com/infant-cognition-tampere/saccademodel-py](https://github.com/infant-cognition-tampere/saccademodel-py).

The algorithm is two-part. The file `saccadeMLE.m` defines the model and computes mean square error (MSE) of model's fit for a single set of model parameters. The file `saccadeEM.m` defines a procedure to iteratively find the set of model parameters that yield the smallest MSE. The files `mletest.m` and `emtest.m` provide usage examples.

## Author

Akseli Palén, akseli.palen@gmail.com

Infant Cognition Laboratory at University of Tampere

## License

MIT License
