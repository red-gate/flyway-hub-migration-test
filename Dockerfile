FROM public.ecr.aws/j7l4v0f3/flywayhub:latest

COPY entrypoint.sh /entrypoint.sh

USER root

ENTRYPOINT ["/entrypoint.sh"]
