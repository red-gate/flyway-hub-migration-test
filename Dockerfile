FROM public.ecr.aws/j7l4v0f3/flywayhub:eafb384d96d70f1d1d9d61ca0cf506c375d1a4d1

COPY entrypoint.sh /entrypoint.sh

USER root

ENTRYPOINT ["/entrypoint.sh"]
