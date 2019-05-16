cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>It takes one shit</h1>
        <ul>
          ${SHIT}
        </ul>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF