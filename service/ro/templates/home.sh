cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>Welcome back, @${USERNAME}!</h1>
        <p class="lead">Lorem ipsum dolor sit...</p>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF