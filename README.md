# CKAD Practice Lab

A comprehensive collection of hands-on Kubernetes exercises designed to prepare you for the **Certified Kubernetes Application Developer (CKAD)** exam.

This lab suite contains 20 practical questions covering all key CKAD domains.

## 📋 Lab Coverage

The practice labs cover the following CKAD exam topics:

- **Secrets** — Creating and consuming Secrets in Deployments
- **CronJobs** — Scheduling jobs with history limits
- **RBAC** — ServiceAccounts, Roles, and RoleBindings
- **Troubleshooting** — Debugging broken Pods and fixing RBAC issues
- **Container Images** — Building and deploying custom images
- **Canary Deployments** — Multi-version deployments with traffic distribution
- **Network Policies** — Fixing and creating network isolation rules
- **Deployment Management** — Scaling, updating, and troubleshooting Deployments
- **Rolling Updates & Rollbacks** — Managing deployment strategies
- **Health Probes** — Implementing readiness and liveness probes
- **Security Contexts** — Pod and container-level security configurations
- **Services** — ClusterIP, NodePort, and Service selectors
- **Ingress** — Creating and fixing Ingress resources
- **Resource Management** — CPU/memory requests and limits, ResourceQuotas
- **Pod Logs** — Debugging multi-container Pods
- **Port Forwarding** — Exposing Pods for debugging
- **Traffic Distribution** — Load balancing across multiple services
- **API Deprecation** — Updating deprecated API versions (HPA v1 → v2)

## 🗂️ Repository Structure

```
2026-CKAD/
├── 1-Secrets/
│   ├── setup.sh        # Sets up the lab environment
│   ├── task.md         # Question description and requirements
│   ├── solution.md     # Step-by-step solution with commands
│   └── verify.sh       # Automated verification script
├── 2-CronJob/
│   ├── setup.sh
│   ├── task.md
│   ├── solution.md
│   └── verify.sh
├── 3-ServiceAccount-RoleBinding/
│   └── ...
...
└── 20-Deprecated_API-Update/
    ├── setup.sh
    ├── task.md
    ├── solution.md
    └── verify.sh
```

## 🚀 Getting Started

### Prerequisites

- **Kubernetes cluster** (v1.24+)
  - Local: [Minikube](https://minikube.sigs.k8s.io/), [Kind](https://kind.sigs.k8s.io/), or [K3s](https://k3s.io/)
  - Cloud: Any managed Kubernetes service
  - Online: [KillerCoda Kubernetes Playground](https://killercoda.com/playgrounds/scenario/kubernetes)
- **kubectl** CLI tool installed and configured
- **bash/zsh** shell environment

### Running Locally

#### 1. Clone the Repository

```bash
git clone git@github.com:CodingT/ckad-lab_2026.git
cd 2026-CKAD
```

#### 2. Choose a Question

Navigate to any question folder (e.g., Question 3):

```bash
cd 3-ServiceAccount-RoleBinding
```

#### 3. Set Up the Lab Environment

Run the setup script to create the initial resources:

```bash
./setup.sh
```

The setup script will:
- Create necessary namespaces, deployments, services, etc.
- Display the task description
- Prepare the environment for you to solve

#### 4. Read the Task

View the task requirements:

```bash
cat task.md
```

#### 5. Work on the Solution

Use `kubectl` commands to solve the task. You can refer to `solution.md` if you get stuck.

#### 6. Verify Your Solution

Run the verification script to check if you've completed the task correctly:

```bash
./verify.sh
```

The script will display color-coded results:
- ✅ **[OK]** — Requirement met
- ❌ **[FAIL]** — Requirement not met

### Running on KillerCoda.com

KillerCoda provides a free Kubernetes playground environment perfect for these labs.

#### 1. Access the Playground

Visit: [https://killercoda.com/playgrounds/scenario/kubernetes](https://killercoda.com/playgrounds/scenario/kubernetes)

#### 2. Upload the Lab Files

**Clone the repository**
```bash
git clone git@github.com:CodingT/ckad-lab_2026.git
cd 2026-CKAD
```

#### 3. Run the Labs

Follow the same workflow as running locally:

```bash
cd 3-ServiceAccount-RoleBinding
./setup.sh
# ... work on solution ...
./verify.sh
```

#### KillerCoda Tips

- Playground sessions last **60 minutes** by default
- The cluster is already configured with kubectl
- You have full cluster-admin access
- Some labs require Ingress controller — install with:
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
  ```

## 📚 How to Use This Lab Suite

### For Exam Preparation

1. **Timed Practice**: Set a timer for 10-15 minutes per question
2. **No Cheating**: Try solving without looking at `solution.md`
3. **Verify Your Work**: Always run `./verify.sh` to ensure correctness
4. **Repeat**: If you fail, re-run `./setup.sh` and try again
5. **Review Solutions**: After solving, compare your approach with `solution.md`

### For Learning

1. **Read the Task**: Understand what's being asked
2. **Check the Solution**: Study the step-by-step approach
3. **Experiment**: Modify the solution and see what happens
4. **Clean Up**: Re-run `./setup.sh` to reset the environment




## 🎯 Tips for CKAD Exam Success

1. **Master Kubernetes Documentation Search**: The official K8s docs are available during the exam! Practice finding examples quickly using the search function. Know where to find YAML examples for common resources (Deployments, Services, Ingress, etc.). Bookmark frequently used pages mentally.
2. **Use kubectl Cheat Sheet**: Keep the [official kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) handy
3. **Master kubectl shortcuts**: Learn aliases like `k` for `kubectl`, `-o yaml`, `--dry-run=client`
4. **Use kubectl run/create**: Generate YAML quickly instead of writing from scratch
5. **Learn vim/nano basics**: You'll need to edit files during the exam
6. **Time management**: Don't spend too long on one question — flag it and move on
7. **Read carefully**: Many failures come from missing a small requirement
8. **Verify your work**: Always check your solution with `kubectl get/describe`

## 📖 Additional Resources

- [Official CKAD Curriculum](https://github.com/cncf/curriculum)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📄 License

This project is provided as-is for educational purposes.

## ⭐ Good Luck!

Remember: **Practice makes perfect!** 

The more you work through these scenarios, the more comfortable you'll be with Kubernetes operations during the exam. Focus on speed and accuracy — both are critical for CKAD success.

Happy learning! 🚀
