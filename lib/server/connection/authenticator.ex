defmodule Yams.Server.Connection.Authenticator do
  @moduledoc """
  This module is responsible for creating tasks that start TLS on sockets and
  perform authentication of the remote device using the supplied client certificate.
  """
  import Ecto.Query, only: [from: 2]
  alias Yams.Database.CertAuth
  alias Yams.Server.Connection


  @doc """
  Starts TLS on a `socket` and runs authentication against the client certificate supplied
  by the remote device.

  If authentication is successful the socket is passed as part of a `Yams.Server.Connection`
  to the specified dynamic `supervisor`.

  Returns `:ok` on success or `{:error, reason}` on failure.
  """
  def run(tls_socket, supervisor) do
    # Authenticate connection and place under the passed dynamic supervisor.
    # Use case to evaluate return from separate auth function and start child under
    #   supervisor or simply exit.
    with {:ok, cert} <- :ssl.peercert(tls_socket),
         %{serial_number: cert_serial, subject: cert_subject} <- EasySSL.parse_der(cert)
    do
      query = from c in CertAuth,
        where: c.serial == ^cert_serial,
        where: c.active == true
      case Yams.Database.Repo.exists?(query) do
        false -> 
          :ssl.send(tls_socket, "Error: Authentication failed")
          :ssl.close(tls_socket)
          {:error, :auth_failed}
        true -> 
          #{:ok, pid} = DynamicSupervisor.start_child(supervisor, {Connection, %Connection{tls_socket: tls_socket}})
          {:ok, _pid} = DynamicSupervisor.start_child(supervisor, {Yams.Server.Connection.Echo,
            %Connection{tls_socket: tls_socket, client_name: cert_subject[:CN], distinguished_name: cert_subject[:aggregated]}})
          :ok
      end
    else
      {:error, _reason} ->
        :ssl.send(tls_socket, "Error: Could not parse client cert")
        :ssl.close(tls_socket)
        {:error, :bad_cert}
      _ ->
        :ssl.send(tls_socket, "Error: Could not authenticate client")
        :ssl.close(tls_socket)
        {:error, :unknown}
    end
  end

end