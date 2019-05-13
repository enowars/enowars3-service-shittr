cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>The world's biggest shit stream!</h1>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF