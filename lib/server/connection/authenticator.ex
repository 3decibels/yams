defmodule Yams.Server.Connection.Authenticator do
  @moduledoc """
  This module is responsible for creating tasks that start TLS on sockets and
  perform authentication of the remote device using the supplied client certificate.
  """
  use Task
  alias Yams.Server.Connection


  @doc """
  Spawns a task to start TLS and perform authentication on a `socket`.

  If authentication is successful the socket will be placed into a `Yams.Server.Connection`
  to be run under the specified dynamic `supervisor`.

  This function is used for the side effect only. Returns tuple `{:ok, pid}` with the pid
  of the started authentication task. The result of the task is not returned.
  """
  def authenticate(tls_socket, supervisor), do: Task.start(__MODULE__, :run, [tls_socket, supervisor])


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
      case true do
        false -> 
          {:error, :auth_failed}
        true -> 
          #{:ok, pid} = DynamicSupervisor.start_child(supervisor, {Connection, %Connection{tls_socket: tls_socket}})
          {:ok, _pid} = DynamicSupervisor.start_child(supervisor, {Yams.Server.Connection.Echo,
            %Connection{tls_socket: tls_socket, client_name: cert_subject[:CN], distinguished_name: cert_subject[:aggregated]}})
          :ok
      end
    else
      {:error, _reason} ->
        :ssl.send(tls_socket, "Error: Could not parse cert")
        :ssl.close(tls_socket)
        {:error, :bad_cert}
      _ ->
        :ssl.send(tls_socket, "Error: Could not parse cert")
        :ssl.close(tls_socket)
        {:error, :unknown}
    end
  end

end