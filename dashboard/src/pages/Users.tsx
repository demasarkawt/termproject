import { useEffect, useMemo, useState } from 'react';
import {
  apiFetch, apiPatch, ApiError, type User,
} from '@/src/lib/api';
import { Users as UsersIcon, Search, ShieldCheck, ChevronUp, ChevronDown, Power } from 'lucide-react';
import { useToast } from '@/src/components/Toast';

export default function Users() {
  const toast = useToast();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [busyId, setBusyId] = useState<number | null>(null);

  const refresh = async () => {
    setLoading(true);
    try {
      setUsers(await apiFetch<User[]>('/api/users/'));
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    return users.filter(
      (u) => !q || u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q),
    );
  }, [users, search]);

  const patchUser = async (
    id: number,
    body: { level?: number; is_active?: boolean },
    successMsg: string,
  ) => {
    setBusyId(id);
    try {
      const updated = await apiPatch<User>(`/api/users/${id}/admin`, body);
      setUsers((prev) => prev.map((u) => (u.id === id ? updated : u)));
      toast.success(successMsg);
    } catch (err) {
      toast.error(err instanceof ApiError ? err.detail ?? err.message : String(err));
    } finally {
      setBusyId(null);
    }
  };

  return (
    <div className="p-8 max-w-5xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-stone-800">Registered Users</h2>
          <p className="text-sm text-stone-500 mt-0.5">{users.length} total accounts</p>
        </div>
      </div>

      <div className="relative mb-6 max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
        <input
          type="text"
          placeholder="Search by name or email…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-stone-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-emerald-400"
        />
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-48 text-stone-400">Loading…</div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center h-48 text-stone-400">
          <UsersIcon className="w-12 h-12 mb-3 opacity-20" />
          <p>No users found</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-stone-100 overflow-hidden shadow-sm">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-stone-100 text-stone-500 text-left">
                <th className="px-6 py-3 font-semibold">ID</th>
                <th className="px-6 py-3 font-semibold">Name</th>
                <th className="px-6 py-3 font-semibold">Email</th>
                <th className="px-6 py-3 font-semibold">Level</th>
                <th className="px-6 py-3 font-semibold">Status</th>
                <th className="px-6 py-3 font-semibold">Joined</th>
                <th className="px-6 py-3 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((u, i) => (
                <tr
                  key={u.id}
                  className={`border-b border-stone-50 hover:bg-stone-50 transition-colors group ${
                    i === filtered.length - 1 ? 'border-b-0' : ''
                  }`}
                >
                  <td className="px-6 py-3 text-stone-400 font-mono">#{u.id}</td>
                  <td className="px-6 py-3 font-medium text-stone-800 flex items-center gap-2">
                    <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center text-xs font-bold">
                      {u.name.charAt(0).toUpperCase()}
                    </div>
                    {u.name}
                  </td>
                  <td className="px-6 py-3 text-stone-500">{u.email}</td>
                  <td className="px-6 py-3">
                    <span className="flex items-center gap-1 text-amber-600 font-semibold">
                      <ShieldCheck className="w-3.5 h-3.5" />
                      Lvl {u.level}
                    </span>
                  </td>
                  <td className="px-6 py-3">
                    <span
                      className={`px-2 py-0.5 rounded-full text-xs font-semibold ${
                        u.is_active
                          ? 'bg-emerald-50 text-emerald-700'
                          : 'bg-red-50 text-red-600'
                      }`}
                    >
                      {u.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="px-6 py-3 text-stone-400">
                    {u.created_at
                      ? new Date(u.created_at).toLocaleDateString('en-GB', {
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })
                      : '—'}
                  </td>
                  <td className="px-6 py-3 text-right">
                    <div className="inline-flex items-center gap-1 opacity-50 group-hover:opacity-100 transition-opacity">
                      <button
                        title="Promote (level +1)"
                        disabled={busyId === u.id}
                        onClick={() =>
                          patchUser(
                            u.id,
                            { level: u.level + 1 },
                            `${u.name} promoted to level ${u.level + 1}.`,
                          )
                        }
                        className="rounded-md p-1.5 text-emerald-700 hover:bg-emerald-50 disabled:opacity-40"
                      >
                        <ChevronUp className="h-4 w-4" />
                      </button>
                      <button
                        title="Demote (level -1)"
                        disabled={busyId === u.id || u.level <= 1}
                        onClick={() =>
                          patchUser(
                            u.id,
                            { level: Math.max(1, u.level - 1) },
                            `${u.name} demoted to level ${Math.max(1, u.level - 1)}.`,
                          )
                        }
                        className="rounded-md p-1.5 text-stone-500 hover:bg-stone-100 disabled:opacity-40"
                      >
                        <ChevronDown className="h-4 w-4" />
                      </button>
                      <button
                        title={u.is_active ? 'Deactivate' : 'Reactivate'}
                        disabled={busyId === u.id}
                        onClick={() =>
                          patchUser(
                            u.id,
                            { is_active: !u.is_active },
                            `${u.name} ${u.is_active ? 'deactivated' : 'reactivated'}.`,
                          )
                        }
                        className={`rounded-md p-1.5 disabled:opacity-40 ${
                          u.is_active
                            ? 'text-red-500 hover:bg-red-50'
                            : 'text-emerald-700 hover:bg-emerald-50'
                        }`}
                      >
                        <Power className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
