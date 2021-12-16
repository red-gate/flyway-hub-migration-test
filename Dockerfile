FROM public.ecr.aws/j7l4v0f3/flywayhub:d7bc96f23ebccf84ecbcc8db667969670f19360d

USER root

RUN apt-get update && apt-get install -y jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
