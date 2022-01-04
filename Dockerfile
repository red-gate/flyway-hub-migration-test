FROM public.ecr.aws/j7l4v0f3/flywayhub:58bb022e707b407c0214f316efea853c30ee6ed7

USER root

RUN apt-get update && apt-get install -y jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
