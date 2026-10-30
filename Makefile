.PHONY: preflight repo bootstrap ui webui verify drift teardown rebuild

preflight:            ## check tools and WSL kernel modules
	bash scripts/preflight.sh

repo:                 ## write your repo URL into the manifests: make repo URL=https://github.com/<you>/telco-gitops-lab.git
	bash scripts/set-repo-url.sh $(URL)

bootstrap:            ## create cluster + Argo CD, then Git drives the rest
	bash scripts/bootstrap.sh

ui:                   ## Argo CD UI on https://localhost:8080
	kubectl -n argocd port-forward svc/argocd-server 8080:443

webui:                ## Open5GS subscriber UI on http://localhost:9999 (admin / 1423)
	kubectl -n open5gs port-forward svc/open5gs-webui 9999:9999

verify:               ## core up, gNB attached, UE ping through the UPF
	bash scripts/verify.sh

drift:                ## delete the AMF and watch Argo CD bring it back
	kubectl -n open5gs delete deploy open5gs-amf
	kubectl -n open5gs get deploy open5gs-amf -w

teardown:             ## delete the cluster
	bash scripts/teardown.sh

rebuild: teardown bootstrap   ## the Week 1 test: rebuild everything from Git
