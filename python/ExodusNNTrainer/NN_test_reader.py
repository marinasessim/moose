import numpy as np
import torch
import matplotlib.pyplot as plt
from time import time
from matplotlib.pyplot import figure
import pickle

##### SET Numpy random seed to generate predictable numbers, this prevents having to save the training and validate sets
#####

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
    torch.nn.Tanh(),
    torch.nn.Linear(H,H),
    torch.nn.Tanh(),
    torch.nn.Linear(H,D_out),
    )



loss_fn = torch.nn.MSELoss(reduction='sum')
model.load_state_dict(torch.load('temp/conc_stress_coupled.pt'))
# model.eval()
# for param in model.parameters():
#     print(param.data)


#generate a sub-sample of the validate data set

X = x_validate[:N]
Y = y_validate[:N]
# X = np.arange(1.5,2.6,1.1/N)
# X=X.reshape((X.shape[0],1) )
# Y = np.arange(1e-6,1,1/N)

#convert to tensors
X = torch.tensor(X,dtype=dtype)
# print(X.shape,x_training.shape)
Y = torch.tensor(Y,dtype=dtype)


Y_pred = model(X)
loss = loss_fn(Y_pred,Y)
# print(loss)

##flatten t

print(X.shape)

fig, (ax1,ax2) = plt.subplots(2,1,sharex=False)
plt.suptitle('NN fit for inverting sub-concentration from MOOSE exodus output')

ax1.scatter(X[:,0],Y,s=20,c='b')
ax1.scatter(X[:,0],Y_pred.detach(),s=10,c='r')
ax1.set_xlabel("$\mu_{Ni}$ ($eV$)",fontsize=16)
ax1.set_ylabel("$c^{metal}_{Ni}$",fontsize=16)
ax1.legend(['Exodus data','NN predictions'])

ax2.scatter(X[:,1],Y,s=20,c='b')
ax2.scatter(X[:,1],Y_pred.detach(),s=10,c='r')
ax1.set_xlabel("$\mu_{Cr}$ ($eV$)",fontsize=16)
ax1.set_ylabel("$c^{metal}_{Ni}$",fontsize=16)
ax2.legend(['Exodus data','NN predictions'])


# plt.title('Mole fraction of component as a function of chemical potential in ideal solution model',fontsize=18)
# plt.legend(['Inverse function','NN fit'],fontsize=16)


# figure(1,figsize=(12,8))
# plt.scatter(X[:,0],Y,s=20,c='b')
# plt.scatter(X[:,0],Y_pred.detach(),s=10,c='r')
# plt.xlabel("$\mu$ ($eV/nm^3$)",fontsize=16)
# plt.ylabel("Component mole fraction",fontsize=16)
# # plt.title('Mole fraction of component as a function of chemical potential in ideal solution model',fontsize=18)
# # plt.legend(['Inverse function','NN fit'],fontsize=16)
#
# figure(2,figsize=(12,8))
# plt.scatter(X[:,1],Y,s=20,c='b')
# plt.scatter(X[:,1],Y_pred.detach(),s=10,c='r')

#
plt.show()

# print(model.parameters())
