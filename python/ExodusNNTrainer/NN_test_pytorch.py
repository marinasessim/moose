import numpy as np
import torch
import matplotlib.pyplot as plt
from time import time
import matplotlib.animation as animation
import pickle

##### SET Numpy random seed to generate predictable numbers, this prevents having to save the training and validate sets
#####

def get_rand_training_data(x,y,training_factor):
    random_choice = np.random.random(x.shape[0])

    x_training = np.asarray([x[i] for i in range(x.shape[0]) if random_choice[i] < training_factor ])
    y_training = np.asarray([y[i] for i in range(x.shape[0]) if random_choice[i] < training_factor ])

    X = torch.tensor(x_training,dtype=dtype)
    Y = torch.tensor(y_training,dtype=dtype)
    return (X,Y)

    # x_validate = np.asarray([x[i] for i in range(x.shape[0]) if random_choice[i] >= training_factor ])
    # y_validate = np.asarray([y[i] for i in range(x.shape[0]) if random_choice[i] >= training_factor ])

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

X,Y = get_rand_training_data(x,y,training_factor)

####setting up the neural net
N,D_in = X.shape #1000,2
D_out = 1
H = 20



#ge


model = torch.nn.Sequential(
    torch.nn.Linear(D_in,H),
    torch.nn.Tanh(),
    torch.nn.Linear(H,H),
    torch.nn.Tanh(),
    torch.nn.Linear(H,D_out),
    )

# model.load_state_dict(torch.load('temp/conc_stress_coupled.pt'))
loss_fn = torch.nn.MSELoss(reduction='sum')
learning_rate = 1e-4
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
t1 = time()
t =0

#We run the epoch till the loss function drops below the threshold
while True:
    # X, Y = get_rand_training_data(x,y,training_factor)
    Y_pred = model(X)

    loss = loss_fn(Y_pred,Y)
    if t % 100 == 0:
        print(t, loss.item())
        torch.save(model.state_dict(),'temp/conc_stress_coupled.pt')

    model.zero_grad()
    loss.backward()

    optimizer.step()
    t += 1
    if(t>1e6 or loss.item()<1e-3):
        torch.save(model.state_dict(),'temp/conc_stress_coupled.pt')
        break

t2 = time()
print(t2 -t1)

# plt.scatter(y,x)
# plt.scatter(model(x).detach(),x)
# plt.xlabel("\mu (eV)")
# plt.ylabel("Component mole fraction")

# print(model.parameters())
