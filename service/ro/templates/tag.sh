cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="">
        $(render messages.sh)
        <div class="row">
          <div class="col-lg-3">
            <h1>#$(htmlEscape "${TAG}")</h1>
          </div>
          <div class="col-lg-9">
            <h1>Shits</h1>
            <table class="table table-hover table-striped table-dark">
            <tbody>
EOF
        for s in "${SHITS[@]}"
        do 
          cat <<EOF
                <tr>
                  <td>${s}</td>
                </tr>
EOF
        done
cat <<EOF
          </tbody>
          </table>
          </div>
        </div>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF