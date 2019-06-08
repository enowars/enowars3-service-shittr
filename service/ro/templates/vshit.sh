cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="">
        $(render messages.sh)
        <h1 style="text-align:center"">It takes one shit</h1>
          <table class="table table-hover table-striped table-dark">
          <tbody>
            <tr>
              <td>${SHIT}</td>
            </tr>
          </tbody>
        </table>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF