cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>When shit hits the fan...</h1>
        <p class="lead">...this is the place to be!</p>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF
