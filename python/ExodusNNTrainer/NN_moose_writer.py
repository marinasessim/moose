#code to test manual implementation of NN
#output NN structure in a simple format for running MOOSE applications

import numpy as np
import torch
import matplotlib.pyplot as plt
from time import time
from matplotlib.pyplot import figure
import pickle

np.random.seed(4)

dtype  = torch.float
device = torch.device("cuda:0") #"cuda:0" for GPU

#Read and reshape arrays into pytorch tensors
with open('temp/two_component_data.pkl','rb') as file:
    container = pickle.load(file)

x = np.vstack( [container['c_Ni'],container['eta'] ])
x=np.transpose(x)
# x=x.reshape((x.shape[0],1) )
y = container['c_Ni_metal'] #np.transpose(np.vstack( [container['c_Ni_metal'],container['c_Ni_melt'] ]))
y=y.reshape((y.shape[0],1) )

#
######reducing sample size to 1000
training_factor = 0.3 # 70% of the data will be used in training

random_choice = np.random.random(x.shape[0])

x_training = np.asarray([x[i] for i in range(x.shape[0]) if random_choice[i] < training_factor ])
y_training = np.asarray([y[i] for i in range(x.shape[0]) if random_choice[i] < training_factor ])

x_validate = np.asarray([x[i] for i in range(x.shape[0]) if random_choice[i] >= training_factor ])
y_validate = np.asarray([y[i] for i in range(x.shape[0]) if random_choice[i] >= training_factor ])

####setting up the neural net
N,D_in = x_training.shape #1000,2
D_out = 1
H = 20

X = torch.tensor(x_training,dtype=dtype)
Y = torch.tensor(y_training,dtype=dtype)

#ge


model = torch.nn.Sequential(
    torch.nn.Linear(D_in,H),
    torch.nn.Sigmoid(),
    torch.nn.Linear(H,H),
    torch.nn.Sigmoid(),
    torch.nn.Linear(H,D_out),
    )

loss_fn = torch.nn.MSELoss(reduction='sum')
model.load_state_dict(torch.load('temp/conc_stress_coupled.pt'))
model.eval()

print("Data format")
for (i,param) in enumerate(model.parameters() ):
    # print("Group ",i)
    N_weights=param.data
    # print(*list(N_weights.detach().shape) )
    for (j,row) in enumerate(N_weights):
        # print("sub-group ",j)
        try:
            print( *[ float(vals) for vals in row] , sep='\n')
        except:
            print( float(row) )                          ##If row tensor is 0D vertical
"""

#testing the eval
X = np.asarray([[0.3,0.5]] )
#
X = torch.tensor(X,dtype=dtype) #.t()
params = model.parameters()
weights=[w.data for w in params]
# # print(len(weights) )
#
# #first layer is linear
F = X.mm( weights[0].t() ) + weights[1]
# # print("Linear 1",F)
#
# # #2 hidden layers
# W = weights[1].shape
# #
# # F = F.mm(weights[1].view(20,1).t() )
F = torch.sigmoid(F)
# print("Hidden sigmoid 1 ",F)
#
F = torch.sigmoid(F)
# # #
# print("Hidden sigmoid 2", F)
# #
F = sum(F.mm(weights[2].t() ) ) + weights[3]
print(F)

# F = torch.sigmoid(F)
# print("Hidden sigmoid 2",F)
#
# #Last linear layer
# F = F.mm(weights[2].t()) + weights[3]
# print("Last linear",F)

# F = F.mm(weights[3])


#
#
# print(weights[2].shape)
#
# for i,param in enumerate(model.parameters()):
#     if(i==0 or i==3):
#         print("Linear layer")
"""
