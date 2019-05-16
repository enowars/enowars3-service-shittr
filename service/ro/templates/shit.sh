cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>Don't shit yourself...</h1>
        <form method="post">
            <textarea name='post'>...shit on the others! </textarea>
            <br>
            <label for='private'>Private?</label><input type='checkbox' name='private'>
            <br>
            <input type='submit' name='submit'>
        </form>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF