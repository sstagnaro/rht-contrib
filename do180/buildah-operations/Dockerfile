FROM ubi7/ubi:7.7
MAINTAINER Your Name <youremail>
LABEL description="A custom Apache container based on UBI 7"
RUN yum install -y httpd && \
yum clean all
RUN echo "Hello from Dockerfile" > /var/www/html/index.html
EXPOSE 80
CMD ["httpd", "-D", "FOREGROUND"]
