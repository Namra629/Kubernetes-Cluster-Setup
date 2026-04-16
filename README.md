# Kubernetes Cluster Set up via kubeadm tool (not minikube cluster setup)

Kubernetes is a powerful container orchestration platform used for automating the deployment, scaling, and management of containerized applications.

# Pre-requisites

-> Ubuntu VM

-> Root user privileges if you are not a root user or owner of the VM, but added as a general user to that VM.

-> Minimum 2GB RAM or more.

-> Minimum 2 CPU cores (or 2 vCPUs).

-> 20 GB of free disk space

# Set up

1.  Edit the hosts files on both the nodes for the nodes to ping ( reach or connect) each other through their names internally instead of IPs. Private IPs are static and fastest to route on ( have traffic) as not serving the traffic from the internet.

           vi /etc/hosts

    Test from opposite nodes. The connectivity is developed so that you can ssh into another node from the one node.

         ping worker
         ping master


3.  Add the nodes Private IPs and their respective names. 

          #Example

           10.0.0.7 master

           10.0.0.8 worker

4.  Open the firewall ports for kubenretes.

        sudo firewall-cmd --permanent --add-port=2379/tcp
        sudo firewall-cmd --permanent --add-port=2380/tcp
        sudo firewall-cmd --permanent --add-port=6443/tcp
        sudo firewall-cmd --permanent --add-port=10248/tcp
        sudo firewall-cmd --permanent --add-port=10250/tcp
        sudo firewall-cmd --permanent --add-port=10257/tcp
        sudo firewall-cmd --permanent --add-port=10259/tcp
        sudo firewall-cmd --reload
        sudo firewall-cmd --list-ports

     If Azure VM, set the network rules like this both for master and worker node using their private IPs.

     <img width="1887" height="690" alt="image" src="https://github.com/user-attachments/assets/90a26d04-b16c-4cab-a651-b455eb772aa0" />


5.  On your local VM as a regular user,  run the scripts of the respective nodes on each node present in the github repository.

          # Make them executable first

           chmod +x master.sh

           # Then run them.

            ./master.sh
    and likeways on worker node.

6.  The master node will be in NotReady state at this time.  On master node , run the commands that appear after running the script.

           #Run these as a regular user.

            mkdir -p $HOME/.kube

            sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

            sudo chown $ (id -u):$ (id -g) $HOME/.kube/config

            #Run this as a root user.

            export KUBECONFIG=/etc/kubernetes/admin.conf



    <img width="1100" height="300" alt="kubeadm init" src="https://github.com/user-attachments/assets/eb27ff68-df65-4d9f-9ba9-5afa3581a7e4" />



7. Check if the kubernetes components ( kubeadm , kubectl , kubelet ) are installed or not.

       kubeadm version
       kubelet version
       kubectl --version

8. Set up the CNI plugin flannel on the master node so that its state appears to be ready.  ( taken from github flannel repo link )

       kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

9.  Run the kubeadm join command on the worker node as a root user.

            kubeadm join 10.0.0.5:6443 --token tpi4er.6ns8zopweoewwmba \
        --discovery-token-ca-cert-hash sha256:2fee5dbf0b9ca44f5c47dbf3ad79eb1c947cdd5030ea06640802b0ce1ffa4da2
        

    <img width="1100" height="300" alt="image" src="https://github.com/user-attachments/assets/ce2121b0-1445-4dc8-883b-21b9f12e8456" />



10. Check the status of the nodes. (On master node)

       kubectl get no


    <img width="647" height="86" alt="nodes ready" src="https://github.com/user-attachments/assets/252fd70f-5d5e-4598-ac07-00bd7a907d62" />

11. Reboot the system to apply the hostname changes -> if required .

         sudo reboot

12.  This token expires in almost 24 hours, to re-create it use this command.

          kubeadm token create --print-join-command

References:  

     Medium Article https://hbayraktar.medium.com/how-to-install-kubernetes-cluster-on-ubuntu-22-04-step-by-step-guide-7dbf7e8f5f99
     Medium Article  https://medium.com/@usmanasim11/setting-up-a-kubernetes-v1-32-0-air-gapped-cluster-with-containerd-flannel-2f2cec6adfe0







