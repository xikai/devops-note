* ApplicationSet 用于简化多集群应用编排，它可以基于单一应用编排并根据用户的编排内容自动生成一个或多个 Application，以部署到多个集群环境
```yml
# applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: guestbook
spec:
  goTemplate: true # 使用 go template 模板
  goTemplateOptions: ["missingkey=error"] # 当模板中缺少键时，抛出错误
  generators: # 生成器，用于生成参数
    - list: # 列表生成器
        elements: # 元素
          - cluster: dev
            url: https://1.2.3.4
          - cluster: staging
            url: https://9.8.7.6
          - cluster: prod
            url: https://kubernetes.default.svc
  template:
    metadata:
      name: "{{.cluster}}-guestbook"
    spec:
      project: demo
      source:
        repoURL: https://gitee.com/cnych/argocd-example-apps
        targetRevision: HEAD
        path: helm-guestbook
        helm:
          valueFiles:
            - "{{.cluster}}.yaml"
      syncPolicy:
        syncOptions:
          - CreateNamespace=true
      destination:
        server: "{{.url}}"
        namespace: guestbook
```