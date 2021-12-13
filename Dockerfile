FROM public.ecr.aws/j7l4v0f3/flywayhub:3c208eb7c4117289aa921d58cf5c33118e222d9f

COPY entrypoint.sh /entrypoint.sh

USER root

ENTRYPOINT ["/entrypoint.sh"]
