# Kubernetes Cluster Set up via kubeadm tool (not minikube cluster setup)

1.  Edit the hosts files on both the nodes 

           vi /etc/hosts

2.  Add the nodes Public IPs and their respective names. 

          #Example

           45.282.443.4 master

           172.234.453.567 worker

3.  On your local VM as a regular user,  run the scripts of the respective nodes on each node present in the github repository.

          # Make them executable first

           chmod +x master.sh

           # Then run them.

            ./master.sh
    and likeways on worker node.

5.  The master node will be in NotReady state at this time.  On master node , run the commands that appear after running the script.

           #Run these as a regular user.

            mkdir -p $HOME/.kube

            sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

            sudo chown $ (id -u):$ (id -g) $HOME/.kube/config

            #Run this as a root user.

            export KUBECONFIG=/etc/kubernetes/admin.conf



    <img width="1100" height="300" alt="kubeadm init" src="https://github.com/user-attachments/assets/eb27ff68-df65-4d9f-9ba9-5afa3581a7e4" />




6. Check if the kubernetes components ( kubeadm , kubectl , kubelet ) are installed or not.

       kubeadm version
       kubelet version
       kubectl --version

7. Set up the CNI plugin flannel on the master node so that its state appears to be ready.

       kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

8.  Run the kubeadm join command on the worker node as a root user.

            kubeadm join 10.0.0.5:6443 --token tpi4er.6ns8zopweoewwmba \
        --discovery-token-ca-cert-hash sha256:2fee5dbf0b9ca44f5c47dbf3ad79eb1c947cdd5030ea06640802b0ce1ffa4da2
        

    <img width="1100" height="300" alt="image" src="https://github.com/user-attachments/assets/ce2121b0-1445-4dc8-883b-21b9f12e8456" />



9. Check the status of the nodes. (On master node)

       kubectl get no


    <img width="647" height="86" alt="nodes ready" src="https://github.com/user-attachments/assets/252fd70f-5d5e-4598-ac07-00bd7a907d62" />


10.  This token expires in almost 24 hours, to re-create it use this command.

          kubeadm token create --print-join-command







