## `helm create`
`helm create foo' will create a directory structure that looks something like this:
```commandline
foo/
├── .helmignore   # Contains patterns to ignore when packaging Helm charts.
├── Chart.yaml    # Information about your chart
├── values.yaml   # The default values for your templates
├── charts/       # Charts that this chart depends on
└── templates/    # The template files
    └── tests/    # The test files
```
Flags:
```
--kubeconfig string    # path to the kubeconfig file
--namespace string     # namespace scope for this request
```